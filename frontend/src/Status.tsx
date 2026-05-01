import { useQuery } from '@tanstack/react-query'

async function fetchHealth(): Promise<string> {
  const res = await fetch('/api/health')
  if (!res.ok) throw new Error(`Health check failed: ${res.status}`)
  return res.text()
}

export const Status = () => {
  const { data, error, isLoading } = useQuery({
    queryKey: ['health'],
    queryFn: fetchHealth,
  })

  const status = isLoading ? 'loading'
    : error ? 'error'
      : data ? 'ok'
        : 'error'

  return (
    <div className={`status-dot ${status}`} />
  )
}
