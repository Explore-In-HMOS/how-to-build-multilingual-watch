import worker, { MessageEvents } from '@ohos.worker';
import { common } from '@kit.AbilityKit';
import { WatchDial } from '../components/WatchDial';
import { FormatPreview } from '../components/FormatPreview';
import { LocaleFormatter } from '../model/LocaleFormatter';
import { Globalization, SystemLocaleInfo } from '../model/Globalization';
import { SendableResourceManager } from '../model/SendableResources';
import { SUPPORTED_LOCALES, LocaleEntry, findLocale, supportedTags } from '../model/LocaleCatalog';

interface WorkerResult {
  time: string;
  fullDate: string;
  stepsLine: string;
  batteryLine: string;
  spendLine: string;
}

@Entry
@Component
struct Index {
  @State activeTag: string = 'en-US';
  @State hour12: boolean = true;
  @State isRTL: boolean = false;

  // Watch-face display state (filled by the worker round-trip).
  @State timeText: string = '';
  @State fullDateText: string = '';
  @State stepsLine: string = '';
  @State batteryLine: string = '';
  @State spendLine: string = '';

  // System globalization snapshot.
  @State systemSummary: string = '';

  // Demo complication values.
  private readonly steps: number = 8421;
  private readonly battery: number = 0.72;
  private readonly spend: number = 49.9;

  private srManager?: SendableResourceManager;
  private fmtWorker?: worker.ThreadWorker;
  private ticker: number = -1;

  aboutToAppear(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.srManager = new SendableResourceManager(ctx);

    // Query system globalization and pick the best matching app locale.
    const info: SystemLocaleInfo = Globalization.querySystem();
    this.activeTag = Globalization.resolveBestLocale(supportedTags());
    this.systemSummary =
      `System: ${info.systemLocale}  |  Pref: ${info.preferredLanguageList.join(', ')}` +
      `  |  24h: ${info.is24Hour}  |  RTL: ${info.isRTL}`;

    const entry: LocaleEntry = findLocale(this.activeTag);
    this.hour12 = !info.is24Hour;
    this.isRTL = Globalization.isRTL(this.activeTag);

    // Spin up the formatting worker.
    this.fmtWorker = new worker.ThreadWorker('entry/ets/workers/format.worker.ets');
    this.fmtWorker.onmessage = (e: MessageEvents): void => {
      const r: WorkerResult = e.data as WorkerResult;
      this.timeText = r.time;
      this.fullDateText = r.fullDate;
      this.stepsLine = r.stepsLine;
      this.batteryLine = r.batteryLine;
      this.spendLine = r.spendLine;
    };

    this.refresh();
    // Tick every second to keep the time live.
    this.ticker = setInterval(() => this.refresh(), 1000);
  }

  aboutToDisappear(): void {
    if (this.ticker !== -1) {
      clearInterval(this.ticker);
    }
    this.srManager?.releaseAll();
    this.fmtWorker?.terminate();
  }

  private async refresh(): Promise<void> {
    if (!this.srManager || !this.fmtWorker) {
      return;
    }
    const entry: LocaleEntry = findLocale(this.activeTag);
    const resource = await this.srManager.acquire(
      this.activeTag,
      entry.currency,
      $r('app.string.label_steps').id,
      $r('app.string.label_battery').id,
      $r('app.string.label_spend').id
    );
    this.fmtWorker.postMessage({
      resource,
      hour12: this.hour12,
      timestamp: Date.now(),
      steps: this.steps,
      battery: this.battery,
      spend: this.spend
    });
  }

  private switchLocale(tag: string): void {
    this.activeTag = tag;
    this.isRTL = Globalization.isRTL(tag);
    this.refresh();
  }

  @Builder
  localeButton(e: LocaleEntry) {
    Button(e.label)
      .fontSize(13)
      .height(36)
      .backgroundColor(this.activeTag === e.tag ? '#4FC3F7' : '#2C2C2C')
      .fontColor(this.activeTag === e.tag ? '#000000' : '#FFFFFF')
      .onClick(() => this.switchLocale(e.tag))
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('i18n Watch Face Codelab')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ top: 30 })

        Text(this.systemSummary)
          .fontSize(11)
          .fontColor('#9E9E9E')
          .textAlign(TextAlign.Center)
          .padding({ left: 12, right: 12 })

        WatchDial({
          timeText: this.timeText,
          dateText: this.fullDateText,
          stepsLabel: '',
          stepsValue: this.stepsLine,
          batteryLabel: '',
          batteryValue: this.batteryLine,
          spendLabel: '',
          spendValue: this.spendLine,
          isRTL: this.isRTL
        })

        // Language picker
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(SUPPORTED_LOCALES, (e: LocaleEntry) => {
            Column() {
              this.localeButton(e)
            }.padding(4)
          },(e: LocaleEntry) => e.label.toString())
        }

        // 12/24h toggle
        Row({ space: 10 }) {
          Text('24-hour clock')
            .fontSize(14)
            .fontColor('#FFFFFF')
          Toggle({ type: ToggleType.Switch, isOn: !this.hour12 })
            .onChange((isOn: boolean) => {
              this.hour12 = !isOn;
              this.refresh();
            })
        }

        FormatPreview({
          sampleTime: Date.now(),
          sampleNumber: 1234567.89,
          sampleAmount: this.spend
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ bottom: 24 })
    }
    .backgroundColor('#0A0A0A')
    .width('100%')
    .height('100%')
    .scrollBarColor(Color.Transparent)
  }
}
