import 'package:flutter/material.dart';

void mostrarSnack(BuildContext context, String texto) {
  mostrarSnackEn(ScaffoldMessenger.of(context), texto);
}

// Version que recibe el messenger ya capturado: sirve cuando el widget que
// lanzo la operacion puede desaparecer antes de que termine (p. ej. un item
// de lista que se elimina)
void mostrarSnackEn(ScaffoldMessengerState messenger, String texto) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}
