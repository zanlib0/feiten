import { useQuery } from '@tanstack/react-query'
import { CartesianGrid, Line, LineChart, XAxis, YAxis } from 'recharts';
import { RechartsDevtools } from '@recharts/devtools';

type Reading = {
  time: string,
  serialno: string,
}

const fetchReadings = async (): Promise<Reading[]> => {
  const res = await fetch('/api/readings')
  if (!res.ok) throw new Error(`Failed to get readings: ${res.status}`)
  return res.json()
}

export const IndexPage = () => {
  const { data: readings, isLoading } = useQuery({
    queryKey: ['readings'],
    queryFn: fetchReadings,
  })

  if (isLoading) return <h1>Feiten</h1>

  return (
    <main>
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
        <RechartsDevtools />
      </LineChart>
    </main >
  )
}
