import {
  generateClassesAndClient,
  generateDartModelFile,
  generateDartModelFilesSeperated,
} from "@/generators";
import { Definitions } from "@/generators/types";
import { NextResponse } from "next/server";

export const GET = async (req: Request): Promise<NextResponse> => {
  // get query params, SUPABASE_URL and SUPABASE_ANON_KEY
  const { searchParams } = new URL(req.url);
  const supabaseUrl = searchParams.get("SUPABASE_URL");
  const supabaseAnonKey = searchParams.get("SUPABASE_ANON_KEY");
  const isDart = !!searchParams.get("dart");
  const isSeperated = !!searchParams.get("seperated");

  if (!supabaseUrl || !supabaseAnonKey) {
    return NextResponse.json({
      data: null,
      error: "SUPABASE_URL and SUPABASE_ANON_KEY are required.",
    });
  }

  try {
    const res = await fetch(
      `${supabaseUrl}/rest/v1/?apikey=${supabaseAnonKey}`
    );
    if (!res.ok) {
      return NextResponse.json(
        { data: null, error: "Error fetching data" },
        { status: 500 }
      );
    }

    const contentType = res.headers.get("content-type");
    if (
      !contentType ||
      contentType.indexOf("application/openapi+json") === -1
    ) {
      return NextResponse.json(
        {
          data: null,
          error: "Invalid Supabase URL or ANON key",
        },
        {
          status: 400,
        }
      );
    }
    const data = await res.json();
    const definitions = data.definitions as Definitions;
    if (!definitions) {
      return NextResponse.json({ data: null, error: "No definitions found" });
    }

    let outputCode: string | Record<string, string> = "";
    if (isSeperated) {
      outputCode = generateDartModelFilesSeperated(definitions, isDart);
    } else {
      outputCode = generateDartModelFile(definitions, isDart);
    }
    return NextResponse.json(
      { data: outputCode, error: null },
      { status: 200 }
    );
  } catch (e) {
    return NextResponse.json(
      { data: null, error: "Error fetching data" },
      { status: 500 }
    );
  }
};
