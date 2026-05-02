import { useDeleteSensor, useSensors } from "../../api/sensors"
import { AddSensor } from "./AddSensor"

import './style.module.css'

export const SensorsPage = () => {
  const { data: sensors = [], isLoading } = useSensors()
  const deleteSensor = useDeleteSensor()

  if (isLoading) return null

  return (
    <div className="container">
      <AddSensor />

      <table>
        <thead>
          <tr>
            <td>ID</td>
            <td>Name</td>
            <td>Serial Number</td>
            <td>Description</td>
            <td />
          </tr>
        </thead>
        <tbody>
          {sensors.map(sensor => (
            <tr key={sensor.id}>
              <td>{sensor.id}</td>
              <td>{sensor.name}</td>
              <td>{sensor.serialno}</td>
              <td>{sensor.description}</td>
              <td>
                <button onClick={() => {
                  deleteSensor.mutate(sensor.id)
                }}>
                  Delete
                </button>
              </td>
            </tr>
          ))}

        </tbody>

      </table>
    </div >
  )
}
