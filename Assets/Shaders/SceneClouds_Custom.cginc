// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Originated from two Shadertoy masterpieces:
//		Clouds by iq: https://www.shadertoy.com/view/XslGRr
//		Cloud Ten by nimitz: https://www.shadertoy.com/view/XtS3DD

uniform sampler2D _NoiseTex;
float noise( in float3 x )
{
	float3 p = floor( x );
	float3 f = frac( x );
	f = f*f*(3.0 - 2.0*f);

	float2 uv2 = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
	float2 rg = tex2Dlod( _NoiseTex, float4((uv2 + 0.5) / 256.0, 0.0, 0.0) ).yx;
	return lerp( rg.x, rg.y, f.z );
}

float4 map( in float3 p, in float t )
{
	float d = -max(0.0, pos.y - _CloudVerticalRange.y / _CloudGranularity);
	d = min(d, pos.y - (_CloudVerticalRange.x + 2*_CloudGranularity) / _CloudGranularity);

	/* Shift the clouds by the "wind" */

	float3 q = pos - _WindDisplacement;
	/* Sample the noise texture by multiple octaves depending on the "quality" of the clouds. */

	float f;
	f = 0.5000*noise( q ); q = q*2.02;



	if (_CloudFade > .5)
		d -= 1.0 - (p.y - _CloudVerticalRange.x) / (_CloudVerticalRange.y - _CloudVerticalRange.x);

	/* Clamp the density of the clouds between 0 and 1. */

	float4 res = (float4)d;
	/* Color the clouds based on their density. */
	float3 col = _OuterColor;;
	res.xyz = lerp( col, _InnerColor, res.x*res.x );
	return res;
}

float4 VolumeSampleColor( in float3 pos, in float t )
{
	// Sample the color of the clouds at pos.
	float4 col = map( pos, t );

	// Color the clouds by the sunlight.
	float dif = clamp( (col.w - map( pos - 0.6*_SunDirection, t ).w), 0.0, 1.0 );
	col.xyz *= col.xyz;
	col.xyz *= lin;
	col.rgb *= col.a;

	return col;
}