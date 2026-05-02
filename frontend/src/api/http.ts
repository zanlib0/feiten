export class ApiError extends Error {
  status: number
  body: unknown

  constructor(status: number, body: unknown, message: string) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.body = body
  }
}

export async function http<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`/api${path}`, {
    ...init,
    headers: { 'Content-Type': 'application/json', ...init?.headers },
  })

  const contentType = res.headers.get('content-type') ?? ''
  let body: unknown
  if (res.status === 204 || res.headers.get('content-length') === '0') {
    body = undefined
  } else if (contentType.includes('application/json')) {
    body = await res.json()
  } else {
    body = await res.text()
  }

  if (!res.ok) {
    throw new ApiError(res.status, body, `${res.status} ${res.statusText} ${path}`)
  }

  return body as T
}
