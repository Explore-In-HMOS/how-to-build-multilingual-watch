/**
 * Static catalog of the locales this watch-face app ships resources for.
 * Each entry pairs a BCP-47 locale tag with its default currency and a
 * human label used in the language picker.
 */
export interface LocaleEntry {
  tag: string;        // BCP-47 locale tag, e.g. "en-US"
  qualifier: string;  // resource directory qualifier, e.g. "en_US"
  label: string;      // native display label
  currency: string;   // ISO-4217 currency for demo currency formatting
}

export const SUPPORTED_LOCALES: LocaleEntry[] = [
  { tag: 'en-US', qualifier: 'en_US', label: 'English (US)', currency: 'USD' },
  { tag: 'de-DE', qualifier: 'de_DE', label: 'Deutsch',      currency: 'EUR' },
  { tag: 'zh-CN', qualifier: 'zh_CN', label: '中文(简体)',    currency: 'CNY' },
  { tag: 'ar-EG', qualifier: 'ar_EG', label: 'العربية',       currency: 'EGP' }
];

export function supportedTags(): string[] {
  return SUPPORTED_LOCALES.map((e) => e.tag);
}

export function findLocale(tag: string): LocaleEntry {
  const hit = SUPPORTED_LOCALES.find((e) => e.tag === tag);
  return hit ?? SUPPORTED_LOCALES[0];
}
