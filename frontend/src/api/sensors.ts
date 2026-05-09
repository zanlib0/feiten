import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { http } from './http'
import { qk } from './keys'

export interface Sensor {
  id: number
  name: string
  serialno: string
  description: string | null
  mqtt_password: string | null
  mqtt_broker_url: string | null
  inserted_at: string
  updated_at: string
}

export interface NewSensor {
  name: string
  serialno: string
  description?: string
}

export interface FieldErrors {
  errors: Record<string, string[]>
}

const listSensors = () => http<Sensor[]>('/sensors')

const createSensor = (input: NewSensor) =>
  http<Sensor>('/sensors', {
    method: 'POST',
    body: JSON.stringify({ data: input }),
  })

const deleteSensor = (id: number) =>
  http<void>(`/sensors/${id}`, { method: 'DELETE' })

export const useSensors = () =>
  useQuery({ queryKey: qk.sensors.list(), queryFn: listSensors })

export const useCreateSensor = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: createSensor,
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.sensors.all }),
  })
}

export const useDeleteSensor = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: deleteSensor,
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.sensors.all }),
  })
}
