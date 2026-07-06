import { LocaleFormatter } from '../model/LocaleFormatter';
import { SUPPORTED_LOCALES, LocaleEntry } from '../model/LocaleCatalog';

interface PreviewRow {
  label: string;
  time: string;
  number: string;
  currency: string;
  separator: string;
}

/**
 * FormatPreview renders a side-by-side table showing how the SAME instant and
 * the SAME numeric values render across every supported locale. This is the
 * "live preview" surface that highlights 24h vs 12h and comma vs dot decimals.
 */
@Component
export struct FormatPreview {
  @Prop sampleTime: number = Date.now();
  @Prop sampleNumber: number = 1234567.89;
  @Prop sampleAmount: number = 49.9;

  private buildRows(): PreviewRow[] {
    const date = new Date(this.sampleTime);
    return SUPPORTED_LOCALES.map((e: LocaleEntry): PreviewRow => {
      const f = new LocaleFormatter(e.tag, e.currency);
      return {
        label: e.label,
        time: f.formatTime(date),
        number: f.formatNumber(this.sampleNumber),
        currency: f.formatCurrency(this.sampleAmount),
        separator: f.decimalSeparator()
      };
    });
  }

  @Builder
  headerCell(text: string) {
    Text(text)
      .fontSize(9)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .layoutWeight(1)
      .textAlign(TextAlign.Start)
  }

  @Builder
  bodyCell(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor('#E0E0E0')
      .layoutWeight(1)
      .textAlign(TextAlign.Start)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  build() {
    Column({ space: 6 }) {
      Text('Live regional format preview')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4FC3F7')

      Row() {
        this.headerCell('Locale')
        this.headerCell('Time')
        this.headerCell('Number')
        this.headerCell('Currency')
        this.headerCell('Dec.')
      }
      .padding(8)
      .backgroundColor('#263238')
      .borderRadius(6)

      ForEach(this.buildRows(), (row: PreviewRow) => {
        Row() {
          this.bodyCell(row.label)
          this.bodyCell(row.time)
          this.bodyCell(row.number)
          this.bodyCell(row.currency)
          this.bodyCell(`"${row.separator}"`)
        }
        .padding(6)
        .backgroundColor('#161616')
        .borderRadius(6)
      },(row: PreviewRow) => row.label.toString())
    }
    .padding(8)
    .width('100%')
  }
}
