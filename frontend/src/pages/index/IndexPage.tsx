import { useQuery } from '@tanstack/react-query'
import { Chart } from './Chart'

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
      <Chart readings={readings} />
    </main>
  )
}
