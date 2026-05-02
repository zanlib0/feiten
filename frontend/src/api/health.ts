import { useQuery } from '@tanstack/react-query'
import { http } from './http'
import { qk } from './keys'

const fetchHealth = () => http<string>('/health')

export const useHealth = () =>
  useQuery({ queryKey: qk.health(), queryFn: fetchHealth })
