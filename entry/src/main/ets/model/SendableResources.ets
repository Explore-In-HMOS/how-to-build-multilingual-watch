import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';

/**
 * Immutable snapshot of locale-specific resource data.
 *
 * @Sendable allows instances to be shared across worker threads by reference
 * (shared memory) rather than being deep-copied on every postMessage call.
 * All fields are string primitives, satisfying the @Sendable type constraint.
 */
@Sendable
export class SendableResource {
  readonly locale: string;
  readonly currency: string;
  readonly stepsLabel: string;
  readonly batteryLabel: string;
  readonly spendLabel: string;

  constructor(
    locale: string,
    currency: string,
    stepsLabel: string,
    batteryLabel: string,
    spendLabel: string
  ) {
    this.locale = locale;
    this.currency = currency;
    this.stepsLabel = stepsLabel;
    this.batteryLabel = batteryLabel;
    this.spendLabel = spendLabel;
  }
}

/**
 * Manages the lifecycle of SendableResource instances.
 *
 * Caches one SendableResource per locale tag so string labels are resolved
 * from resourceManager only once per locale. Call acquire() to get-or-create,
 * release() to evict a single entry, and releaseAll() on component teardown.
 */
export class SendableResourceManager {
  private readonly rm: resourceManager.ResourceManager;
  private readonly cache: Map<string, SendableResource> = new Map();

  constructor(context: common.UIAbilityContext) {
    this.rm = context.resourceManager;
  }

  /**
   * Returns a cached SendableResource for the given locale tag, resolving
   * string labels in the target locale's resource directory on the first call.
   *
   * getConfiguration() is async; a fresh copy is awaited so we can safely
   * set its locale field without mutating any shared reference. The resulting
   * ResourceManager resolves strings from the correct qualifier directory
   * (e.g. de_DE, zh_CN) regardless of the device's system locale.
   */
  async acquire(
    localeTag: string,
    currency: string,
    stepsResId: number,
    batteryResId: number,
    spendResId: number
  ): Promise<SendableResource> {
    const hit = this.cache.get(localeTag);
    if (hit) {
      return hit;
    }
    // getConfiguration() returns a fresh Configuration copy each call, so
    // mutating its locale field does not affect any other caller.
    const config: resourceManager.Configuration = await this.rm.getConfiguration();
    config.locale = localeTag;
    const localizedRm = this.rm.getOverrideResourceManager(config);
    const resource = new SendableResource(
      localeTag,
      currency,
      localizedRm.getStringSync(stepsResId),
      localizedRm.getStringSync(batteryResId),
      localizedRm.getStringSync(spendResId)
    );
    this.cache.set(localeTag, resource);
    return resource;
  }

  /** Evicts the cached resource for the given locale tag. */
  release(localeTag: string): void {
    this.cache.delete(localeTag);
  }

  /** Evicts all cached resources. Call this on component teardown. */
  releaseAll(): void {
    this.cache.clear();
  }
}
