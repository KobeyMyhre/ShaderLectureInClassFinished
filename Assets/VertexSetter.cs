using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VertexSetter : MonoBehaviour {

	public Material mat;
	public Transform[] poses;
	//public float rotPerSec;
	// Use this for initialization
	void Start () {
		
	}
	
	void OnDrawGizmos()
	{
		if(mat == null){return;}
		Vector4[] arr = new Vector4[3];
		for(int i =0; i < poses.Length; i++)
		{
			arr[i] = new Vector4(poses[i].position.x, poses[i].position.y, poses[i].position.z,0);
		}
		
		mat.SetVectorArray("_VectorPos",arr);
	}

	// Update is called once per frame
	void Update () {
		//transform.Rotate(0,rotPerSec * Time.deltaTime,0);
	}
}
