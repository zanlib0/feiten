import { useState } from 'react'

import { Chart } from './Chart'
import { useReadings, type Range } from '../../api/readings'

import styles from './style.module.css'

export const IndexPage = () => {
  const [range, setRange] = useState<Range>('hour')
  const { data: readings = [], isLoading } = useReadings(range)

  if (isLoading) return <h1>Loading</h1>

  return (
    <>
      <div className={styles.filters}>
        <select onChange={e => setRange(e.target.value as Range)}>
          <option value="hour">Last hour</option>
          <option value="day">Last day</option>
          <option value="week">Last week</option>
          <option value="month">Last month</option>
        </select>
      </div>
      <main>
        <Chart readings={readings} field="co2" />
        <Chart readings={readings} field="pm1" />
        <Chart readings={readings} field="pm2" />
        <Chart readings={readings} field="pm10" />
        <Chart readings={readings} field="temperature" />
        <Chart readings={readings} field="humidity" />
        <Chart readings={readings} field="voc" />
        <Chart readings={readings} field="nox" />
      </main>
    </>
  )
}

