import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to ExpoPreventCapture.web.ts
// and on native platforms to ExpoPreventCapture.ts
import ExpoPreventCaptureModule from './ExpoPreventCaptureModule';
import ExpoPreventCaptureView from './ExpoPreventCaptureView';
import { ChangeEventPayload, ExpoPreventCaptureViewProps } from './ExpoPreventCapture.types';

// Get the native constant value.
export const PI = ExpoPreventCaptureModule.PI;

export function hello(): string {
  return ExpoPreventCaptureModule.hello();
}

export async function setValueAsync(value: string) {
  return await ExpoPreventCaptureModule.setValueAsync(value);
}

const emitter = new EventEmitter(ExpoPreventCaptureModule ?? NativeModulesProxy.ExpoPreventCapture);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { ExpoPreventCaptureView, ExpoPreventCaptureViewProps, ChangeEventPayload };
