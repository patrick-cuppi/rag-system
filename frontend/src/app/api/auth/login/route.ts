import { NextRequest, NextResponse } from 'next/server';

const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8000';

export async function POST(request: NextRequest) {
  const formData = await request.formData();

  const response = await fetch(`${BACKEND_URL}/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      username: (formData.get('username') as string) ?? '',
      password: (formData.get('password') as string) ?? '',
    }),
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: 'Login failed' }));
    return NextResponse.json(error, { status: response.status });
  }

  const data = await response.json();
  const isProduction = process.env.NODE_ENV === 'production';

  const res = NextResponse.json({ success: true });
  res.cookies.set('access_token', data.access_token, {
    httpOnly: true,
    secure: isProduction,
    sameSite: 'lax',
    maxAge: 30 * 60,
    path: '/',
  });
  if (data.refresh_token) {
    res.cookies.set('refresh_token', data.refresh_token, {
      httpOnly: true,
      secure: isProduction,
      sameSite: 'lax',
      maxAge: 7 * 24 * 60 * 60,
      path: '/',
    });
  }

  return res;
}
