/**
 * LocaleFormatter wraps the standard ECMA-402 Intl API for locale-aware
 * formatting of dates, times, numbers and currencies. All formatters are
 * rebuilt whenever the active locale changes.
 */
export class LocaleFormatter {
  private locale: string;
  private timeFormat!: Intl.DateTimeFormat;
  private dateFormat!: Intl.DateTimeFormat;
  private fullDateFormat!: Intl.DateTimeFormat;
  private numberFormat!: Intl.NumberFormat;
  private percentFormat!: Intl.NumberFormat;
  private currencyFormat!: Intl.NumberFormat;
  private currencyCode: string;
  private hour12: boolean;

  constructor(locale: string, currencyCode: string = 'USD', hour12?: boolean) {
    this.locale = locale;
    this.currencyCode = currencyCode;
    this.hour12 = hour12 ?? this.deriveHour12(locale);
    this.buildFormatters();
  }

  /** Heuristic default: en-US uses 12h, most others 24h. */
  private deriveHour12(locale: string): boolean {
    const lower = locale.toLowerCase();
    return lower.startsWith('en-us') || lower.startsWith('en_us');
  }

  private buildFormatters(): void {
    this.timeFormat = new Intl.DateTimeFormat(this.locale, {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: this.hour12
    });

    this.dateFormat = new Intl.DateTimeFormat(this.locale, {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });

    this.fullDateFormat = new Intl.DateTimeFormat(this.locale, {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    this.numberFormat = new Intl.NumberFormat(this.locale, {
      style: 'decimal',
      maximumFractionDigits: 2
    });

    this.percentFormat = new Intl.NumberFormat(this.locale, {
      style: 'percent',
      maximumFractionDigits: 1
    });

    this.currencyFormat = new Intl.NumberFormat(this.locale, {
      style: 'currency',
      currency: this.currencyCode
    });
  }

  getLocale(): string {
    return this.locale;
  }

  isHour12(): boolean {
    return this.hour12;
  }

  /** Toggle 12/24h convention at runtime and rebuild time formatter. */
  setHour12(hour12: boolean): void {
    this.hour12 = hour12;
    this.timeFormat = new Intl.DateTimeFormat(this.locale, {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: this.hour12
    });
  }

  formatTime(date: Date): string {
    return this.timeFormat.format(date);
  }

  formatDate(date: Date): string {
    return this.dateFormat.format(date);
  }

  formatFullDate(date: Date): string {
    return this.fullDateFormat.format(date);
  }

  formatNumber(value: number): string {
    return this.numberFormat.format(value);
  }

  formatPercent(value: number): string {
    return this.percentFormat.format(value);
  }

  formatCurrency(value: number): string {
    return this.currencyFormat.format(value);
  }

  /** Returns the decimal separator used by this locale (e.g. "." or ","). */
  decimalSeparator(): string {
    const sample = this.numberFormat.format(1.1);
    return sample.replace(/[0-9٠-٩۰-۹]/g, '');
  }
}