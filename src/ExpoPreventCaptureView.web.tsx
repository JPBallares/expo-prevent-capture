import * as React from 'react';

import { ExpoPreventCaptureViewProps } from './ExpoPreventCapture.types';

export default function ExpoPreventCaptureView(props: ExpoPreventCaptureViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
