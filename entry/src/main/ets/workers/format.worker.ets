import worker, { ThreadWorkerGlobalScope, MessageEvents } from '@ohos.worker';
import intl from '@ohos.intl';
import { SendableResource } from '../model/SendableResources';

/**
 * format.worker.ets
 *
 * Off-loads watch-face string assembly to a Worker thread. The main thread
 * acquires a SendableResource (shared by reference across threads) and posts
 * it together with the runtime metric values.
 */

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

interface FormatJob {
  resource: SendableResource;
  hour12: boolean;
  timestamp: number;
  steps: number;
  battery: number;
  spend: number;
}

interface FormatResult {
  time: string;
  fullDate: string;
  stepsLine: string;
  batteryLine: string;
  spendLine: string;
}

workerPort.onmessage = (e: MessageEvents): void => {
  const job: FormatJob = e.data as FormatJob;
  const res: SendableResource = job.resource;

  const date = new Date(job.timestamp);

  const timeFmt = new Intl.DateTimeFormat(res.locale, {
    hour: '2-digit',
    minute: '2-digit',
    hour12: job.hour12
  });
  const dateFmt = new Intl.DateTimeFormat(res.locale, {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
  const numFmt = new intl.NumberFormat(res.locale, { style: 'decimal' });
  const pctFmt = new intl.NumberFormat(res.locale, {
    style: 'percent',
    maximumFractionDigits: 0
  });
  const curFmt = new intl.NumberFormat(res.locale, {
    style: 'currency',
    currency: res.currency
  });

  const result: FormatResult = {
    time: timeFmt.format(date),
    fullDate: dateFmt.format(date),
    stepsLine: `${res.stepsLabel}: ${numFmt.format(job.steps)}`,
    batteryLine: `${res.batteryLabel}: ${pctFmt.format(job.battery)}`,
    spendLine: `${res.spendLabel}: ${curFmt.format(job.spend)}`
  };

  workerPort.postMessage(result);
};

workerPort.onmessageerror = (): void => {};
workerPort.onerror = (): void => {};
