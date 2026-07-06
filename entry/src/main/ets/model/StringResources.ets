import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';

/**
 * StringResources resolves locale-specific string and media resources via
 * the application's resourceManager. The resourceManager automatically
 * selects the correct qualifier directory (en_US, zh_CN, ar_EG, de_DE, ...)
 * based on the active system / overridden configuration.
 */
export class StringResources {
  private rm: resourceManager.ResourceManager;

  constructor(context: common.UIAbilityContext) {
    this.rm = context.resourceManager;
  }

  /** Synchronously resolve a string resource by its $r id. */
  getString(resId: number): string {
    return this.rm.getStringSync(resId);
  }

  /** Resolve a string with positional format arguments. */
  getStringFormat(resId: number, ...args: Array<string | number>): string {
    return this.rm.getStringSync(resId, ...args);
  }

  /** Resolve a plural string (ICU plural rules per locale). */
  getPlural(resId: number, num: number): string {
    return this.rm.getPluralStringValueSync(resId, num);
  }

  /** Load raw media (e.g. a locale-specific watch-face background) as bytes. */
  async getMedia(resId: number): Promise<Uint8Array> {
    return await this.rm.getMediaContent(resId);
  }

}
