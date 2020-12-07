using System.Collections;
using UnityEngine;

public class MatrixEffectController : MonoBehaviour
{
    [SerializeField]
    private float _slowMoTimeScale = 0;
    [SerializeField]
    private Material _shockWaveMat;
    IEnumerator Start()
    {
        _shockWaveMat.SetFloat("_StartShockWave", 0);
        //enabling the animator after a little delay so the effect can be viewed properly
        yield return new WaitForSeconds(.5f);
        GetComponent<Animator>().enabled = true;
    }

    public void StartGroundDistortion()
    {
        _shockWaveMat.SetVector("_StartPos", transform.position);
        _shockWaveMat.SetFloat("_StartShockWave", 1);
        _shockWaveMat.SetFloat("_CurrTime", Time.time);
        _shockWaveMat.SetFloat("_Speed", 40);
    }

    public void StartSlowMo()
    {
        Time.timeScale = _slowMoTimeScale;
    }
    public void EndSlowMo()
    {
        Time.timeScale = 1;
    }
}

