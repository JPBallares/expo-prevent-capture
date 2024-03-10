import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ExpoPreventCaptureViewProps } from './ExpoPreventCapture.types';

const NativeView: React.ComponentType<ExpoPreventCaptureViewProps> =
  requireNativeViewManager('ExpoPreventCapture');

export default function ExpoPreventCaptureView(props: ExpoPreventCaptureViewProps) {
  return <NativeView {...props} />;
}
