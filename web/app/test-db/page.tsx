import { supabase } from '@/lib/supabase'

export default async function TestDb() {
  const { data: dishes, error } = await supabase
    .from('dishes')
    .select('*')
    .order('name')

  return (
    <div className="min-h-screen bg-[#f5f0e8] p-12">
      <div className="mx-auto max-w-4xl">
        <h1
          className="mb-8 text-4xl font-bold text-stone-900"
          style={{ fontFamily: 'var(--font-playfair), Georgia, serif' }}
        >
          Database Test
        </h1>

        {error && (
          <div className="mb-6 rounded border border-red-300 bg-red-50 p-4 text-red-900">
            <strong>Error:</strong> {error.message}
          </div>
        )}

        {!error && dishes && (
          <>
            <p className="mb-6 text-stone-700">
              Found {dishes.length} dishes in the database.
            </p>

            <div className="overflow-x-auto rounded border border-stone-300 bg-white">
              <pre className="p-6 text-xs text-stone-800">
                {JSON.stringify(dishes, null, 2)}
              </pre>
            </div>
          </>
        )}
      </div>
    </div>
  )
}