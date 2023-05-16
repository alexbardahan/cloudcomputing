String formatDateTime(DateTime chosenDate) {
  String luna;
  switch (chosenDate.month) {
    case 1:
      luna = 'Ianuarie';
      break;
    case 2:
      luna = 'Februarie';
      break;
    case 3:
      luna = 'Martie';
      break;
    case 4:
      luna = 'Aprilie';
      break;
    case 5:
      luna = 'Mai';
      break;
    case 6:
      luna = 'Iunie';
      break;
    case 7:
      luna = 'Iulie';
      break;
    case 8:
      luna = 'August';
      break;
    case 9:
      luna = 'Septembrie';
      break;
    case 10:
      luna = 'Octombrie';
      break;
    case 11:
      luna = 'Noiembrie';
      break;
    case 12:
      luna = 'Decembrie';
      break;
  }

  return chosenDate.day.toString() +
      ' ' +
      luna +
      ', ora ' +
      (chosenDate.hour.toString().length == 1
          ? '0' + chosenDate.hour.toString()
          : chosenDate.hour.toString()) +
      ':' +
      (chosenDate.minute.toString().length == 1
          ? '0' + chosenDate.minute.toString()
          : chosenDate.minute.toString());
}
