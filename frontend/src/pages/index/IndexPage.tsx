import { Chart } from './Chart'
import { useReadings } from '../../api/readings'

export const IndexPage = () => {
  const { data: readings, isLoading } = useReadings()

  if (isLoading) return <h1>Feiten</h1>

  return (
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
  )
}

