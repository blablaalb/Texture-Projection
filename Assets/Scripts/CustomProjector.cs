using UnityEngine;

[ExecuteInEditMode]
public class CustomProjector : MonoBehaviour
{
    [SerializeField]
    private Material _material;

    internal void Update()
    {
        SetMatrix();
    }

    private void SetMatrix()
    {
        _material?.SetMatrix("_ProjectionMatrix", Camera.main.projectionMatrix);
       _material?.SetMatrix("_ViewMatrix", Camera.main.worldToCameraMatrix) ;
    }
}