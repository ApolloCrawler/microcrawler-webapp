import React from 'react';
import { createDevTools } from 'redux-devtools';
import FilterMonitor from 'redux-devtools-filter-actions';
import LogMonitor from 'redux-devtools-log-monitor';
import DockMonitor from 'redux-devtools-dock-monitor';
import SliderMonitor from 'redux-slider-monitor';

const blacklist = [
  'FILE_DOWNLOAD_SUCCESS'
];
export default createDevTools(
  <DockMonitor toggleVisibilityKey="ctrl-H" changePositionKey="ctrl-Q" changeMonitorKey="ctrl-m" defaultIsVisible={false}>
    <FilterMonitor blacklist={blacklist}>
      <LogMonitor />
    </FilterMonitor>
    <SliderMonitor />
  </DockMonitor>
);
