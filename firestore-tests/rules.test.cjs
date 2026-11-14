// Pruebas de firestore.rules. Ejecutar con `npm test` dentro de esta carpeta
// (necesita Java para el emulador de Firestore).
const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment, assertFails, assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, collectionGroup,
  getDocs, query, where, writeBatch, runTransaction,
} = require('firebase/firestore');

const casos = [];
const caso = (nombre, fn) => casos.push([nombre, fn]);

let env;
const db = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

const usuario = (extra = {}) => ({
  nombre: 'Ana', apellido: 'Paz', correo: 'ana@x.co', rol: 'usuario',
  activo: true, especialidad: '', mascotas: [], ...extra,
});
const cita = (extra = {}) => ({
  duenoUid: 'ana', mascota: 'Luna', mascotaId: 'm1', servicio: 'Vacunación',
  fecha: '2030-01-10', hora: '09:00', veterinarioId: null,
  veterinarioNombre: null, estado: 'pendiente', notas: '', ...extra,
});
const cupo = (extra = {}) => ({
  veterinarioId: 'vet1', fecha: '2030-01-10', hora: '09:00',
  duenoUid: 'ana', citaId: 'c1', ...extra,
});

async function sembrar() {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const d = ctx.firestore();
    await setDoc(doc(d, 'usuarios/ana'), usuario());
    await setDoc(doc(d, 'usuarios/beto'), usuario({ nombre: 'Beto', correo: 'beto@x.co' }));
    await setDoc(doc(d, 'usuarios/admin'), usuario({ rol: 'admin' }));
    await setDoc(doc(d, 'usuarios/vet1'), usuario({ rol: 'veterinario', nombre: 'Vet', apellido: 'Uno' }));
    await setDoc(doc(d, 'usuarios/vet2'), usuario({ rol: 'veterinario', nombre: 'Vet', apellido: 'Dos' }));
    await setDoc(doc(d, 'usuarios/vetInactivo'), usuario({ rol: 'veterinario', activo: false }));
    await setDoc(doc(d, 'productos/p1'), { nombre: 'Collar', descripcion: '', precio: 20000, stock: 5, activo: true });
    // Cita de Ana con vet1 (con su cupo) y cita de Beto con vet2.
    await setDoc(doc(d, 'usuarios/ana/citas/c0'), cita({ veterinarioId: 'vet1', veterinarioNombre: 'Vet Uno', hora: '08:00' }));
    await setDoc(doc(d, 'agenda/vet1_2030-01-10_08:00'), cupo({ hora: '08:00', citaId: 'c0' }));
    await setDoc(doc(d, 'usuarios/beto/citas/b0'), cita({ duenoUid: 'beto', veterinarioId: 'vet2', veterinarioNombre: 'Vet Dos' }));
    await setDoc(doc(d, 'usuarios/ana/pedidos/o0'), { uid: 'ana', clienteNombre: 'Ana Paz', fecha: '2030-01-01', total: 20000, estado: 'pendiente', items: [{ productoId: 'p1', nombre: 'Collar', precio: 20000, cantidad: 1 }] });
  });
}

// ── Usuarios y roles ────────────────────────────────────────────────────────
caso('sin sesión no se lee nada', async () => {
  await assertFails(getDoc(doc(anon(), 'usuarios/ana')));
  await assertFails(getDoc(doc(anon(), 'productos/p1')));
});
caso('un usuario NO puede hacerse admin ni veterinario', async () => {
  await assertFails(updateDoc(doc(db('ana'), 'usuarios/ana'), { rol: 'admin' }));
  await assertFails(updateDoc(doc(db('ana'), 'usuarios/ana'), { rol: 'veterinario' }));
  await assertFails(setDoc(doc(db('ana'), 'usuarios/ana'), usuario({ rol: 'admin' })));
});
caso('al registrarse solo se crea una cuenta de usuario normal', async () => {
  await assertSucceeds(setDoc(doc(db('nuevo'), 'usuarios/nuevo'), usuario()));
  await assertFails(setDoc(doc(db('nuevo2'), 'usuarios/nuevo2'), usuario({ rol: 'admin' })));
  await assertFails(setDoc(doc(db('nuevo3'), 'usuarios/otro'), usuario()));
});
caso('un usuario edita sus datos y mascotas, pero no los de otro', async () => {
  await assertSucceeds(updateDoc(doc(db('ana'), 'usuarios/ana'), { nombre: 'Ana María', mascotas: [{ id: 'm1', nombre: 'Luna' }] }));
  await assertFails(updateDoc(doc(db('ana'), 'usuarios/beto'), { nombre: 'x' }));
  await assertFails(getDoc(doc(db('ana'), 'usuarios/beto')));
});
caso('un veterinario desactivado no puede reactivarse', async () => {
  await assertFails(updateDoc(doc(db('vetInactivo'), 'usuarios/vetInactivo'), { activo: true }));
});
caso('cualquiera con sesión lista a los veterinarios, pero no a los usuarios', async () => {
  await assertSucceeds(getDocs(query(collection(db('ana'), 'usuarios'), where('rol', '==', 'veterinario'))));
  await assertFails(getDocs(collection(db('ana'), 'usuarios')));
});
caso('el veterinario abre un perfil pero no lista usuarios; solo edita mascotas', async () => {
  await assertSucceeds(getDoc(doc(db('vet1'), 'usuarios/ana')));
  await assertFails(getDocs(collection(db('vet1'), 'usuarios')));
  await assertSucceeds(updateDoc(doc(db('vet1'), 'usuarios/ana'), { mascotas: [{ id: 'm1', nombre: 'Luna', vacunas: [{ nombre: 'Rabia' }] }] }));
  await assertFails(updateDoc(doc(db('vet1'), 'usuarios/ana'), { rol: 'admin' }));
  await assertFails(updateDoc(doc(db('vet1'), 'usuarios/ana'), { correo: 'otro@x.co' }));
  await assertFails(getDoc(doc(db('vetInactivo'), 'usuarios/ana')));
});
caso('el admin gestiona usuarios y veterinarios', async () => {
  await assertSucceeds(getDocs(collection(db('admin'), 'usuarios')));
  await assertSucceeds(updateDoc(doc(db('admin'), 'usuarios/vet1'), { activo: false, especialidad: 'Felinos' }));
  await assertSucceeds(setDoc(doc(db('admin'), 'usuarios/vet9'), usuario({ rol: 'veterinario' })));
});

// ── Citas y agenda ──────────────────────────────────────────────────────────
caso('agendar sin veterinario', async () => {
  await assertSucceeds(setDoc(doc(db('ana'), 'usuarios/ana/citas/c1'), cita()));
});
caso('agendar con veterinario exige reservar el cupo en la misma escritura', async () => {
  const d = db('ana');
  await assertFails(setDoc(doc(d, 'usuarios/ana/citas/c1'), cita({ veterinarioId: 'vet1' })));
  await assertFails(setDoc(doc(d, 'agenda/vet1_2030-01-10_09:00'), cupo()));
  const b = writeBatch(d);
  b.set(doc(d, 'usuarios/ana/citas/c1'), cita({ veterinarioId: 'vet1', veterinarioNombre: 'Vet Uno' }));
  b.set(doc(d, 'agenda/vet1_2030-01-10_09:00'), cupo());
  await assertSucceeds(b.commit());
});
caso('no se puede reservar un horario ya ocupado', async () => {
  const d = db('beto');
  const b = writeBatch(d);
  b.set(doc(d, 'usuarios/beto/citas/b1'), cita({ duenoUid: 'beto', veterinarioId: 'vet1', hora: '08:00' }));
  b.set(doc(d, 'agenda/vet1_2030-01-10_08:00'), cupo({ hora: '08:00', duenoUid: 'beto', citaId: 'b1' }));
  await assertFails(b.commit());
});
caso('el cupo debe coincidir con su id y con la cita', async () => {
  const d = db('ana');
  let b = writeBatch(d);
  b.set(doc(d, 'usuarios/ana/citas/c1'), cita({ veterinarioId: 'vet1' }));
  b.set(doc(d, 'agenda/vet1_2030-01-10_10:00'), cupo()); // id no coincide con la hora
  await assertFails(b.commit());
  b = writeBatch(d);
  b.set(doc(d, 'usuarios/ana/citas/c1'), cita({ veterinarioId: 'vet1' }));
  b.set(doc(d, 'agenda/vet2_2030-01-10_09:00'), cupo({ veterinarioId: 'vet2' })); // otro veterinario
  await assertFails(b.commit());
});
caso('no se agenda a nombre de otro, ni ya atendida, ni con notas', async () => {
  await assertFails(setDoc(doc(db('ana'), 'usuarios/beto/citas/x'), cita({ duenoUid: 'beto' })));
  await assertFails(setDoc(doc(db('ana'), 'usuarios/ana/citas/x'), cita({ estado: 'atendida' })));
  await assertFails(setDoc(doc(db('ana'), 'usuarios/ana/citas/x'), cita({ notas: 'ok' })));
});
caso('el dueño solo puede cancelar: no borra ni cambia otros datos', async () => {
  const d = db('ana');
  await assertFails(deleteDoc(doc(d, 'usuarios/ana/citas/c0')));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/citas/c0'), { estado: 'atendida' }));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/citas/c0'), { veterinarioId: 'vet2' }));
  const b = writeBatch(d);
  b.update(doc(d, 'usuarios/ana/citas/c0'), { estado: 'cancelada' });
  b.delete(doc(d, 'agenda/vet1_2030-01-10_08:00'));
  await assertSucceeds(b.commit());
  await assertFails(updateDoc(doc(d, 'usuarios/ana/citas/c0'), { estado: 'cancelada' })); // ya no está pendiente
});
caso('nadie libera el cupo de otro usuario', async () => {
  await assertFails(deleteDoc(doc(db('beto'), 'agenda/vet1_2030-01-10_08:00')));
});
caso('el veterinario solo ve y atiende SUS citas', async () => {
  const d = db('vet1');
  const mias = await assertSucceeds(getDocs(query(collectionGroup(d, 'citas'), where('veterinarioId', '==', 'vet1'))));
  if (mias.size !== 1) throw new Error(`esperaba 1 cita, hubo ${mias.size}`);
  await assertFails(getDocs(collectionGroup(d, 'citas')));
  await assertFails(getDocs(query(collectionGroup(d, 'citas'), where('veterinarioId', '==', 'vet2'))));
  await assertFails(getDoc(doc(d, 'usuarios/beto/citas/b0')));
  await assertSucceeds(updateDoc(doc(d, 'usuarios/ana/citas/c0'), { estado: 'atendida', notas: 'Todo bien' }));
  await assertSucceeds(updateDoc(doc(d, 'usuarios/ana/citas/c0'), { estado: 'pendiente' }));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/citas/c0'), { fecha: '2031-01-01' }));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/citas/c0'), { estado: 'cancelada' }));
  await assertFails(updateDoc(doc(d, 'usuarios/beto/citas/b0'), { estado: 'atendida', notas: '' }));
});
caso('el admin ve todas las citas y asigna veterinario', async () => {
  const d = db('admin');
  await assertSucceeds(getDocs(collectionGroup(d, 'citas')));
  await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'usuarios/ana/citas/c1'), cita()));
  await assertSucceeds(runTransaction(d, async (tx) => {
    const c = doc(d, 'agenda/vet2_2030-01-10_09:00');
    if ((await tx.get(c)).exists()) throw new Error('ocupado');
    tx.set(c, cupo({ veterinarioId: 'vet2' }));
    tx.update(doc(d, 'usuarios/ana/citas/c1'), { veterinarioId: 'vet2', veterinarioNombre: 'Vet Dos' });
  }));
});
caso('un usuario no ve las citas de los demás', async () => {
  await assertFails(getDocs(collectionGroup(db('ana'), 'citas')));
  await assertFails(getDoc(doc(db('ana'), 'usuarios/beto/citas/b0')));
  await assertSucceeds(getDocs(collection(db('ana'), 'usuarios/ana/citas')));
  await assertSucceeds(getDocs(query(collection(db('ana'), 'agenda'), where('veterinarioId', '==', 'vet1'), where('fecha', '==', '2030-01-10'))));
});

// ── Tienda: stock y pedidos ─────────────────────────────────────────────────
const pedido = (extra = {}) => ({
  uid: 'ana', clienteNombre: 'Ana Paz', fecha: '2030-01-02', total: 40000,
  estado: 'pendiente', items: [{ productoId: 'p1', nombre: 'Collar', precio: 20000, cantidad: 2 }], ...extra,
});
caso('comprar: baja el stock, crea el pedido y vacía el carrito en una transacción', async () => {
  const d = db('ana');
  await assertSucceeds(setDoc(doc(d, 'usuarios/ana/carrito/p1'), { nombre: 'Collar', precio: 20000, cantidad: 2 }));
  await assertSucceeds(runTransaction(d, async (tx) => {
    const p = await tx.get(doc(d, 'productos/p1'));
    tx.update(doc(d, 'productos/p1'), { stock: p.data().stock - 2 });
    tx.delete(doc(d, 'usuarios/ana/carrito/p1'));
    tx.set(doc(d, 'usuarios/ana/pedidos/o1'), pedido());
  }));
});
caso('un cliente no puede cambiar precio, nombre ni visibilidad, ni subir stock', async () => {
  const d = db('ana');
  await assertFails(updateDoc(doc(d, 'productos/p1'), { precio: 0 }));
  await assertFails(updateDoc(doc(d, 'productos/p1'), { stock: 4, precio: 1 }));
  await assertFails(updateDoc(doc(d, 'productos/p1'), { activo: false }));
  await assertFails(updateDoc(doc(d, 'productos/p1'), { stock: 99 }));
  await assertFails(updateDoc(doc(d, 'productos/p1'), { stock: -1 }));
  await assertFails(deleteDoc(doc(d, 'productos/p1')));
  await assertFails(setDoc(doc(d, 'productos/p2'), { nombre: 'x', precio: 1, stock: 1, activo: true }));
});
caso('un pedido se crea pendiente y el cliente no lo puede alterar después', async () => {
  const d = db('ana');
  await assertFails(setDoc(doc(d, 'usuarios/ana/pedidos/o2'), pedido({ estado: 'entregado' })));
  await assertFails(setDoc(doc(d, 'usuarios/ana/pedidos/o2'), pedido({ uid: 'beto' })));
  await assertFails(setDoc(doc(d, 'usuarios/ana/pedidos/o2'), pedido({ items: [] })));
  await assertFails(setDoc(doc(d, 'usuarios/beto/pedidos/o2'), pedido()));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/pedidos/o0'), { total: 1 }));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/pedidos/o0'), { estado: 'entregado' }));
  await assertFails(deleteDoc(doc(d, 'usuarios/ana/pedidos/o0')));
  await assertSucceeds(getDocs(collection(d, 'usuarios/ana/pedidos')));
  await assertFails(getDocs(collection(d, 'usuarios/beto/pedidos')));
  await assertFails(getDocs(collectionGroup(d, 'pedidos')));
});
caso('el admin ve todos los pedidos, cambia su estado y repone stock', async () => {
  const d = db('admin');
  await assertSucceeds(getDocs(collectionGroup(d, 'pedidos')));
  await assertSucceeds(updateDoc(doc(d, 'usuarios/ana/pedidos/o0'), { estado: 'listo' }));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/pedidos/o0'), { estado: 'regalado' }));
  await assertFails(updateDoc(doc(d, 'usuarios/ana/pedidos/o0'), { total: 0 }));
  await assertSucceeds(updateDoc(doc(d, 'productos/p1'), { stock: 50, precio: 25000 }));
});
caso('el carrito es privado', async () => {
  await assertSucceeds(setDoc(doc(db('ana'), 'usuarios/ana/carrito/p1'), { cantidad: 1 }));
  await assertFails(getDocs(collection(db('beto'), 'usuarios/ana/carrito')));
});
caso('servicios y catálogo: todos leen, solo el admin escribe', async () => {
  await assertSucceeds(getDocs(collection(db('ana'), 'servicios')));
  await assertFails(setDoc(doc(db('ana'), 'servicios/s1'), { nombre: 'x' }));
  await assertFails(setDoc(doc(db('vet1'), 'vacunas_catalogo/v1'), { nombre: 'x' }));
  await assertSucceeds(setDoc(doc(db('admin'), 'servicios/s1'), { nombre: 'x' }));
});

(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-huellitas',
    firestore: { rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8') },
  });
  let fallos = 0;
  for (const [nombre, fn] of casos) {
    await sembrar();
    try { await fn(); console.log('  ok  ', nombre); }
    catch (e) { fallos++; console.log('  FALLA', nombre, '\n        ', String(e.message || e).split('\n')[0]); }
  }
  await env.cleanup();
  console.log(`\n${casos.length - fallos}/${casos.length} casos pasan`);
  process.exit(fallos ? 1 : 0);
})();
