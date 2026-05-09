import { Fragment, useState } from "react"
import { useDeleteSensor, useSensors, type Sensor } from "../../api/sensors"
import { AddSensor } from "./AddSensor"

import style from './style.module.css'

export const SensorsPage = () => {
  const { data: sensors = [], isLoading } = useSensors()
  const deleteSensor = useDeleteSensor()
  const [expandedId, setExpandedId] = useState<number | null>(null)

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
            <td />
          </tr>
        </thead>
        <tbody>
          {sensors.map(sensor => (
            <Fragment key={sensor.id}>
              <tr>
                <td>{sensor.id}</td>
                <td>{sensor.name}</td>
                <td>{sensor.serialno}</td>
                <td>{sensor.description}</td>
                <td>
                  <button
                    onClick={() =>
                      setExpandedId(expandedId === sensor.id ? null : sensor.id)
                    }
                  >
                    {expandedId === sensor.id ? 'Hide config' : 'Show config'}
                  </button>
                </td>
                <td>
                  <button onClick={() => {
                    deleteSensor.mutate(sensor.id)
                  }}>
                    Delete
                  </button>
                </td>
              </tr>
              {expandedId === sensor.id && (
                <tr>
                  <td colSpan={6}>
                    <ConfigPanel sensor={sensor} />
                  </td>
                </tr>
              )}
            </Fragment>
          ))}

        </tbody>

      </table>
    </div >
  )
}

const ConfigPanel = ({ sensor }: { sensor: Sensor }) => {
  const [copied, setCopied] = useState(false)

  if (!sensor.mqtt_broker_url) {
    return <p>No MQTT credentials available for this sensor.</p>
  }

  const curl = [
    `curl -X PUT -H "Content-Type: application/json" \\`,
    `  -d '{"mqttBrokerUrl":"${sensor.mqtt_broker_url}"}' \\`,
    `  http://airgradient_${sensor.serialno}.local/config`,
  ].join('\n')

  const handleCopy = async () => {
    await navigator.clipboard.writeText(curl)
    setCopied(true)
    setTimeout(() => setCopied(false), 1500)
  }

  return (
    <div className={style.configPanel}>
      <p>
        Run this on a host that can resolve <code>airgradient_{sensor.serialno}.local</code>
        {' '}to point the sensor at the broker:
      </p>
      <pre className={style.configCommand}>{curl}</pre>
      <button onClick={handleCopy}>{copied ? 'Copied' : 'Copy'}</button>
    </div>
  )
}
