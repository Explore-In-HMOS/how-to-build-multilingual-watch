import { Complication } from './Complication';

/**
 * WatchDial renders the round watch face: large time, date underneath, and a
 * row of complications. It honours RTL layout direction so Arabic mirrors
 * correctly. All strings are pre-formatted by the caller (LocaleFormatter or
 * the worker), so this component is purely presentational.
 */
@Component
export struct WatchDial {
  @Prop timeText: string = '';
  @Prop dateText: string = '';
  @Prop stepsLabel: string = '';
  @Prop stepsValue: string = '';
  @Prop batteryLabel: string = '';
  @Prop batteryValue: string = '';
  @Prop spendLabel: string = '';
  @Prop spendValue: string = '';
  @Prop isRTL: boolean = false;

  build() {
    Stack() {
      // Round bezel
      Circle()
        .width(300)
        .height(300)
        .fill('#000000')
        .stroke('#2C2C2C')
        .strokeWidth(6)

      Column({ space: 10 }) {
        Text(this.timeText)
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .fontFeature('"tnum" 1') // tabular figures so digits don't jump

        Text(this.dateText)
          .fontSize(14)
          .fontColor('#BDBDBD')
          .maxLines(2)
          .textAlign(TextAlign.Center)
          .width(220)

        Row({ space: 8 }) {
          Complication({ label: this.stepsLabel, value: this.stepsValue, accent: '#81C784' })
          Complication({ label: this.batteryLabel, value: this.batteryValue, accent: '#FFB74D' })
        }

        Complication({ label: this.spendLabel, value: this.spendValue, accent: '#4FC3F7' })
      }
      .alignItems(HorizontalAlign.Center)
      .padding(30)
    }
    .width(300)
    .height(300)
    .direction(this.isRTL ? Direction.Rtl : Direction.Ltr)
  }
}
