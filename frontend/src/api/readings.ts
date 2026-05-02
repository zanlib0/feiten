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

const listRecentReadings = () => http<Reading[]>('/readings')

export const useReadings = () =>
  useQuery({ queryKey: qk.readings.recent(), queryFn: listRecentReadings })
