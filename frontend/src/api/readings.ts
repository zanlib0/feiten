import { useQuery } from '@tanstack/react-query'
import { http } from './http'
import { qk } from './keys'

export interface Reading {
  time: string
  serialno: string
  pm1: number
  pm2: number
  pm10: number
  temperature: number
  humidity: number
  voc: number
  nox: number
  co2: number
}

export type Range = 'hour' | 'day' | 'week' | 'month'

const listRecentReadings = (range: Range = 'hour') => http<Reading[]>(`/readings?range=${range}`)

export const useReadings = (range: Range = 'hour') =>
  useQuery({ queryKey: qk.readings.recent(range), queryFn: () => listRecentReadings(range) })
