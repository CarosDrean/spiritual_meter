import 'package:flutter/cupertino.dart';

const String kAppName = 'Medidor Espiritual';
const String kPhraseTitle = 'Frases';
const String kAddPhraseButtonText = 'Agregar Frase';
const String kStartSectionTitle = 'Comenzar';
const String kPrayerText = 'Comenzar a orar';
const String kBibleReadingText = 'Comenzar lectura bíblica';
const String kStatisticsTitle = 'Estadísticas de la semana';
const String kTimerDialogTitle = 'Tiempo Contando';
const String kStopButtonText = 'Detener';
const String kDailyLogButtonText = 'Ver Registro Hoy';
const String kStartSectionTitleDialog = 'Tiempo';

const Color kPrimaryColor = CupertinoColors.activeGreen;
const Color kAccentColor = CupertinoColors.activeBlue;
const Color kDestructiveColor = CupertinoColors.systemRed;

const Color kChartLineColor1 = CupertinoColors.activeBlue;
const Color kChartLineColor2 = CupertinoColors.systemRed;
const Color kChartGridColor = CupertinoColors.systemGrey4;

const String kActivityTypePrayer = 'prayer';
const String kActivityTypeBibleReading = 'bibleReading';

const List<String> kNoPrayerMessages = [
  "Aún no has orado hoy. Recuerda que la oración es tu fortaleza. ¡Empieza ahora!",
  "El poder del cristiano está en la oración. Dedica unos minutos hoy y verás la diferencia.",
  "Ora y vencerás, ora y las cosas saldrán mejor, mucho mejor. ¡Comienza ya!",
];

const List<String> kRedMessages = [
  "Has orado poco hoy, no te desanimes, sigue adelante y verás cambios.",
  "La oración constante trae paz. Dedica unos minutos más y siente la diferencia.",
  "Cada minuto en oración fortalece tu espíritu. ¡No te rindas!",
];

const List<String> kYellowMessages = [
  "Vas bien, sigue con esa constancia en la oración para crecer cada día más.",
  "La perseverancia en la oración abre puertas. ¡No te detengas ahora!",
  "Tu tiempo en oración te acerca más a Dios. Sigue con esa disciplina.",
];

const List<String> kGreenMessages = [
  "¡Excelente! Has dedicado un buen tiempo a orar, sigue así y crecerás mucho.",
  "Tu constancia en la oración es un gran ejemplo, continúa con fe y alegría.",
  "La oración constante trae bendiciones. ¡Sigue fortaleciendo tu espíritu!",
];