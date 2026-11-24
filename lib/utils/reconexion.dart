// Tiempo real sin conexión: si un Stream de Supabase falla (cambio de wifi a
// datos, señal débil), el Bloc avisa con este mensaje y se vuelve a
// suscribir solo después de [esperaReconexion].

/// Aviso que ve el usuario mientras se reconecta.
const mensajeSinConexion = 'Se perdió la conexión. Reconectando…';

/// Cuánto espera el Bloc antes de volver a suscribirse.
const esperaReconexion = Duration(seconds: 3);
