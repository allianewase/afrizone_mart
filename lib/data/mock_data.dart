class Application {
  final String name, detail, tier;
  const Application(this.name, this.detail, this.tier);
}

class Payment {
  final String name, detail, amount, note;
  const Payment(this.name, this.detail, this.amount, this.note);
}

class SpendDay {
  final String day;
  final double pct;
  const SpendDay(this.day, this.pct);
}

const applications = [
  Application('Chidi Okafor', 'Campus survey · UNILAG · 2h ago', 'student'),
  Application('Musa Abdullahi', 'Ikeja same-day dispatch · 5h ago', 'rider'),
  Application('Blessing Eze', 'Product data cleanup · remote · 1d ago', 'remote'),
  Application('Tunde Adeyemi', 'Store fit-out · Lekki · 1d ago', 'trade'),
  Application('Fatima Aliyu', 'Weekend promo staff · Surulere · 2d ago', 'student'),
];

const payments = [
  Payment('Blessing Eze', 'Data cleanup · timesheet approved', '₦64,000', 'release now'),
  Payment('Musa Abdullahi', '12 dispatch runs · this week', '₦38,500', 'release now'),
  Payment('Tunde Adeyemi', 'Fit-out · fixed fee · delivered', '₦120,000', 'review first'),
];

const flags = [
  'Clock-in outside geofence — Surulere promo · 2 workers 340m off-site',
  'KYC re-verification due for 5 riders · expires end of month',
  '2 tasks under-filled for tomorrow · Lekki inventory count',
];

const weeklySpend = [
  SpendDay('Mon', 42),
  SpendDay('Tue', 61),
  SpendDay('Wed', 38),
  SpendDay('Thu', 78),
  SpendDay('Fri', 95),
  SpendDay('Sat', 54),
  SpendDay('Sun', 22),
];
