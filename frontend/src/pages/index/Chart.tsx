import { CartesianGrid, Line, Tooltip, LineChart, XAxis, YAxis, ResponsiveContainer } from 'recharts';

import styles from './style.module.css'
import type { Reading } from '../../api/readings';

type Props = {
  readings: Reading[],
  field: string,
  label: string,
  unit?: string,
}

export const Chart = ({ readings, field, label, unit }: Props) => (
  <figure className={`paper-card ${styles.chartContainer}`}>
    <figcaption className={styles.caption}>
      <span>{label}</span>
      {unit && <span className="t-meta">{unit}</span>}
    </figcaption>
    <div className={styles.chartFrame}>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={readings} margin={{ top: 4, right: 8, bottom: 4, left: 0 }}>
          <CartesianGrid stroke="var(--rule-soft)" strokeDasharray="2 4" />
          <XAxis
            dataKey="time"
            stroke="var(--ink-2)"
            tick={{ fill: 'var(--ink-2)', fontSize: 13 }}
            tickFormatter={date => new Date(date).toLocaleTimeString('pl-PL', { hour: '2-digit', minute: '2-digit' })}
          />
          <YAxis
            dataKey={field}
            stroke="var(--ink-2)"
            tick={{ fill: 'var(--ink-2)', fontSize: 13 }}
            width={44}
          />
          <Line
            type="monotone"
            dataKey={field}
            stroke="var(--accent-solid)"
            strokeWidth={1.25}
            dot={false}
            activeDot={{ r: 3, fill: 'var(--accent-solid)', stroke: 'var(--paper)' }}
            isAnimationActive={false}
          />
          <Tooltip
            contentStyle={{
              background: 'var(--surface-raised)',
              border: 'var(--rule-1) solid var(--rule)',
              borderRadius: 0,
              boxShadow: 'var(--overlay-lift)',
              padding: 'var(--space-2) var(--space-3)',
              fontSize: 'var(--text-ui)',
              lineHeight: 'var(--leading-ui)',
              color: 'var(--ink)',
            }}
            cursor={{ stroke: 'var(--rule-strong)', strokeDasharray: '2 2' }}
            labelFormatter={(date) => new Date(date).toLocaleString()}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  </figure>
)
