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
    <main className="container">
      <div className={style.row}>
        <h2 className="t-heading">Sensors</h2>
        <AddSensor />
      </div>

      <table className={`data-table ${style.sensors}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Serial number</th>
            <th>Description</th>
            <th />
            <th />
          </tr>
        </thead>
        <tbody>
          {sensors.map(sensor => (
            <Fragment key={sensor.id}>
              <tr>
                <td className="t-tabular">{sensor.id}</td>
                <td>{sensor.name}</td>
                <td className="t-mono">{sensor.serialno}</td>
                <td>{sensor.description}</td>
                <td>
                  <button
                    className="stamp-button -small -ghost"
                    onClick={() =>
                      setExpandedId(expandedId === sensor.id ? null : sensor.id)
                    }
                  >
                    {expandedId === sensor.id ? 'Hide config' : 'Show config'}
                  </button>
                </td>
                <td>
                  <button
                    className="stamp-button -small -ghost"
                    onClick={() => deleteSensor.mutate(sensor.id)}
                  >
                    Delete
                  </button>
                </td>
              </tr>
              {expandedId === sensor.id && (
                <tr>
                  <td colSpan={6} className={style.configCell}>
                    <ConfigPanel sensor={sensor} />
                  </td>
                </tr>
              )}
            </Fragment>
          ))}
        </tbody>
      </table>
    </main>
  )
}

const ConfigPanel = ({ sensor }: { sensor: Sensor }) => {
  const [copied, setCopied] = useState(false)

  if (!sensor.mqtt_broker_url) {
    return <p className="t-body">No MQTT credentials available for this sensor.</p>
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
    <div className={`paper-card ${style.configPanel}`}>
      <p className="t-body">
        Run this on a host that can resolve{' '}
        <code className="t-mono">airgradient_{sensor.serialno}.local</code> to
        point the sensor at the broker:
      </p>
      <pre className={style.configCommand}>{curl}</pre>
      <button className="stamp-button -small" onClick={handleCopy}>
        {copied ? 'Copied' : 'Copy'}
      </button>
    </div>
  )
}
