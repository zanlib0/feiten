import { useState } from 'react'

import { Chart } from './Chart'
import { useReadings, type Range } from '../../api/readings'

import styles from './style.module.css'

const FIELDS: { key: string; label: string; unit?: string }[] = [
  { key: 'co2', label: 'CO₂', unit: 'ppm' },
  { key: 'pm1', label: 'PM 1.0', unit: 'µg/m³' },
  { key: 'pm2', label: 'PM 2.5', unit: 'µg/m³' },
  { key: 'pm10', label: 'PM 10', unit: 'µg/m³' },
  { key: 'temperature', label: 'Temperature', unit: '°C' },
  { key: 'humidity', label: 'Humidity', unit: '%' },
  { key: 'voc', label: 'VOC index' },
  { key: 'nox', label: 'NOₓ index' },
]

export const IndexPage = () => {
  const [range, setRange] = useState<Range>('hour')
  const { data: readings = [], isLoading } = useReadings(range)

  return (
    <main className="container">
      <div className={styles.head}>
        <h2 className="t-heading">Readings</h2>
        <label className="form-field -boxed">
          <span className="label">Range</span>
          <select className="input" value={range} onChange={e => setRange(e.target.value as Range)}>
            <option value="hour">Last hour</option>
            <option value="day">Last day</option>
            <option value="week">Last week</option>
            <option value="month">Last month</option>
          </select>
        </label>
      </div>

      {isLoading ? (
        <p className="t-body">Loading…</p>
      ) : (
        <div className={styles.grid}>
          {FIELDS.map(f => (
            <Chart key={f.key} readings={readings} field={f.key} label={f.label} unit={f.unit} />
          ))}
        </div>
      )}
    </main>
  )
}
