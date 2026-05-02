import { useHealth } from './api/health'

export const Status = () => {
  const { data, error, isLoading } = useHealth()

  const status = isLoading ? 'loading'
    : error ? 'error'
      : data ? 'ok'
        : 'error'

  return (
    <div className={`status-dot ${status}`} />
  )
}
