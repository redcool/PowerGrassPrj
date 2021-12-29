using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SendPlayerPos : MonoBehaviour
{
    public bool canControl = true;
    public float speed = 4;

    Rigidbody r;

    public Material grassMat;
    public bool controlCullingAnim = true;
    public float cullDistance = 10;

    // Start is called before the first frame update
    void Start()
    {
        r = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        if (canControl)
        {
            var h = Input.GetAxis("Horizontal");
            var v = Input.GetAxis("Vertical");
            var newPos = new Vector3(h, 0, v) * (Time.deltaTime * speed);
            if (r)
            {
                r.MovePosition(transform.position + newPos);
            }
            else
            {
                transform.Translate(newPos);
            }
        }

        Shader.SetGlobalVector("_PlayerPos", transform.position);

        if (controlCullingAnim)
        {
            grassMat.SetVector("_CullPos", transform.position);
            grassMat.SetFloat("_CullDistance", cullDistance);
        }
    }
}
