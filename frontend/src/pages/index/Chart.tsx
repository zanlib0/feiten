import { CartesianGrid, Line, Tooltip, LineChart, XAxis, YAxis } from 'recharts';

import styles from './style.module.css'
import type { Reading } from '../../api/readings';

type Props = {
  readings: Reading[],
  field: string,
}

export const Chart = ({ readings, field }: Props) => (
  <>
    <div className={styles.chartContainer}>
      <h3>{field}</h3>
      <LineChart style={{ height: '12rem', aspectRatio: 1.618 }} data={readings}>
        <CartesianGrid />
        <XAxis dataKey="time" stroke="gray" tickFormatter={date => (new Date(date)).toLocaleTimeString('pl-PL', { hour: '2-digit', minute: '2-digit' })} />
        <YAxis dataKey={field} width="auto" stroke="gray" />
        <Line
          type="monotone"
          dataKey={field}
          stroke="red"
          dot={{
            fill: 'red',
          }}
          activeDot={{
            stroke: 'red',
          }}
        />
        <Tooltip />
      </LineChart>
    </div>
  </>
)
