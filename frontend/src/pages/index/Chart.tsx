import { CartesianGrid, Line, LineChart, XAxis, YAxis } from 'recharts';

type Props = {
  readings: any,
  field: string,
}

export const Chart = ({ readings, field }: Props) => (
  <LineChart style={{ width: '100%', aspectRatio: 1.618, maxWidth: 800, margin: 'auto' }} responsive data={readings}>
    <CartesianGrid stroke="gray" strokeDasharray="5 5" />
    <XAxis dataKey="time" stroke="gray" />
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
  </LineChart>
)
