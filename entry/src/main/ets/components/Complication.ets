/**
 * Complication: a small labelled value tile shown on the watch face, the
 * way real wearables show steps / battery / etc. around the dial.
 */
@Component
export struct Complication {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop accent: ResourceColor = '#4FC3F7';

  build() {
    Column({ space: 2 }) {
      Text(this.label)
        .fontSize(11)
        .fontColor('#9E9E9E')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(this.value)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.accent)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding(8)
    .borderRadius(12)
    .backgroundColor('#1A1A1A')
    .alignItems(HorizontalAlign.Center)
    .constraintSize({ minWidth: 92 })
  }
}
