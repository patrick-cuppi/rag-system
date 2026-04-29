import { NextRequest, NextResponse } from 'next/server';

const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8000';

export async function POST(request: NextRequest) {
  const token = request.cookies.get('access_token')?.value;
  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const body = await request.json();

  const response = await fetch(`${BACKEND_URL}/api/chat`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(body),
  });

  if (response.status === 401) {
    const res = NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    res.cookies.set('access_token', '', { maxAge: 0, path: '/' });
    return res;
  }

  if (!response.ok) {
    return NextResponse.json({ error: 'Chat request failed' }, { status: response.status });
  }

  return NextResponse.json(await response.json());
}
