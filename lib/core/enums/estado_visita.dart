enum EstadoVisita {
  pendiente,
  visitado,
  noCompro,
  postergado,
}

EstadoVisita mapEstadoVisita(String raw) {
  switch (raw) {
    case 'cliente_compra':
      return EstadoVisita.visitado;
    case 'cliente_no_compra':
      return EstadoVisita.noCompro;
    case 'postergacion_cliente':
      return EstadoVisita.postergado;
    default:
      return EstadoVisita.pendiente;
  }
}