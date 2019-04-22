Shader "Custom/Lambert"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM // ここからシェーダープログラムという意味

			#pragma vertex vert // Vertex Shader には vert という関数を使う
			#pragma fragment frag // Fragment Shader には frag という関数を使う
			
			struct appdata // 各頂点ごとのデータの構造体
			{
				float4 vertex : POSITION; // 位置
				float3 normal : NORMAL; // 法線
			};

			struct v2f // Fragment シェーダに送るデータの構造体
			{
				float4 vertex : SV_POSITION; // 位置
				float3 normal : NORMAL; // 法線
			};

			// Vertex Shader
			// 頂点ごとに実行される
			v2f vert (appdata v)
			{
				// return する構造体を宣言
				v2f o;

				// モデルの座標変換をする
				o.vertex =
				mul(
					UNITY_MATRIX_P, // 画面上のに変換（Projection）
					mul(
						UNITY_MATRIX_V, // カメラ座標に変換（View）
						mul(
							unity_ObjectToWorld, // ワールド座標に変換（Model）
							float4(v.vertex.xyz, 1.0) // 頂点の座標、最後の1はおまじない
						)
					)
				);
				// ↑ 書き下したけど、Unityの場合、↓ の関数で同様のことができる
				// o.vertex = UnityObjectToClipPos(v.vertex);
				//
				// Unity のシェーダーのソースは公開されているので、困ったら探す
				// https://github.com/TwoTailsGames/Unity-Built-in-Shaders/blob/bab22c6c04df30e674a47f225e946072c86222cb/CGIncludes/UnityShaderUtilities.cginc#L32-L43

				// 法線の座標変換をする（ややこしいので説明しない）
				o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				return o;
			}
			
			// Fragment Shader
			// これは塗るピクセルごとに実行される
			fixed4 frag (v2f i) : SV_TARGET
			{
				// 法線とライトの向き（の逆）の内積を取る
				// この値が拡散反射の強さ
				float diffuse = dot(
					i.normal, // 法線
					float3(0, 1, 0) // ライトの向き（の逆）
				);

				float3 color = float3(1, 0, 0); // 色、RGB

				// 塗る色を return する
				// 最後の1はアルファ（透明度）
				return float4(color * diffuse, 1);
			}

			ENDCG // ここまでシェーダープログラムという意味
		}
	}
}
