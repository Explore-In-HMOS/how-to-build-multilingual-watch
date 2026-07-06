import i18n from '@ohos.i18n';

/**
 * SystemLocaleInfo aggregates the device's globalization state queried
 * through @ohos.i18n (the Globalization kit). This includes the system
 * locale, the user's ordered preferred-language list, calendar / number
 * conventions and 24-hour clock preference.
 */
export interface SystemLocaleInfo {
  systemLocale: string;
  preferredLanguageList: string[];
  firstPreferredLanguage: string;
  region: string;
  is24Hour: boolean;
  isRTL: boolean;
}

export class Globalization {
  /**
   * Reads the current system globalization settings. Every call re-queries
   * @ohos.i18n so it reflects live changes the user makes in Settings.
   */
  static querySystem(): SystemLocaleInfo {
    const systemLocale: string = i18n.System.getSystemLanguage();
    const preferredLanguageList: string[] = i18n.System.getPreferredLanguageList();
    const firstPreferredLanguage: string = i18n.System.getFirstPreferredLanguage();
    const region: string = i18n.System.getSystemRegion();
    const is24Hour: boolean = i18n.System.is24HourClock();
    const isRTL: boolean = i18n.isRTL(systemLocale);

    return {
      systemLocale,
      preferredLanguageList,
      firstPreferredLanguage,
      region,
      is24Hour,
      isRTL
    };
  }

  /** True if the given locale is written right-to-left (Arabic, Hebrew, ...). */
  static isRTL(locale: string): boolean {
    return i18n.isRTL(locale);
  }

  /**
   * Returns the localized display name of a language code as rendered in
   * the target display locale. e.g. localeDisplayName('zh', 'en-US') -> "Chinese".
   */
  static languageDisplayName(language: string, displayLocale: string): string {
    return i18n.System.getDisplayLanguage(language, displayLocale, true);
  }

  /** Localized display name of a region code, e.g. ('EG','en-US') -> "Egypt". */
  static regionDisplayName(region: string, displayLocale: string): string {
    return i18n.System.getDisplayCountry(region, displayLocale, true);
  }

  /**
   * Picks the best app-supported locale given the user's preferred-language
   * list. Falls back to the first supported locale when nothing matches.
   */
  static resolveBestLocale(supported: string[]): string {
    const prefs: string[] = i18n.System.getPreferredLanguageList();
    for (const pref of prefs) {
      const prefLang: string = pref.split('-')[0].toLowerCase();
      for (const sup of supported) {
        if (sup.toLowerCase().startsWith(prefLang)) {
          return sup;
        }
      }
    }
    return supported.length > 0 ? supported[0] : 'en-US';
  }
}
