import { CartesianGrid, Line, LineChart, XAxis, YAxis } from 'recharts';

type Props = {
  readings: any,
  key: string,
}

export const Chart = ({ readings }: Props) => (
  <LineChart style={{ width: '100%', aspectRatio: 1.618, maxWidth: 800, margin: 'auto' }} responsive data={readings}>
    <CartesianGrid stroke="white" strokeDasharray="5 5" />
    <XAxis dataKey="time" stroke="white" />
    <YAxis dataKey="co2" width="auto" stroke="white" />
    <Line
      type="monotone"
      dataKey="co2"
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
