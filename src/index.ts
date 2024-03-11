import { EventEmitter, Subscription } from "expo-modules-core";

// Import the native module. On web, it will be resolved to ExpoPreventCapture.web.ts
// and on native platforms to ExpoPreventCapture.ts
import ExpoPreventCaptureModule from "./ExpoPreventCaptureModule";

const emitter = new EventEmitter(ExpoPreventCaptureModule);

const onScreenshotEventName = "onScreenshot";

export function addScreenshotListener(listener: () => void): Subscription {
  return emitter.addListener<void>(onScreenshotEventName, listener);
}

export function removeScreenshotListener(subscription: Subscription) {
  emitter.removeSubscription(subscription);
}

export const enableSecureView = () => {
  ExpoPreventCaptureModule.enableSecureView();
};
