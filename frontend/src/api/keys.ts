export const qk = {
  health: () => ['health'] as const,
  sensors: {
    all: ['sensors'] as const,
    list: () => ['sensors', 'list'] as const,
  },
  readings: {
    recent: (range: string) => ['readings', 'recent', range] as const,
  },
}
