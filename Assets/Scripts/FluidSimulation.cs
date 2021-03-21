using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class FluidSimulation : MonoBehaviour
{
    [SerializeField] private Shader qtyInput;

    //ADF
    [SerializeField] private Shader advection;
    [SerializeField] private Shader diffuse;
    [SerializeField] private Shader force;

    //Projection
    [SerializeField] private Shader pressureDivergence;
    [SerializeField] private Shader computePressure;
    [SerializeField] private Shader substractPresureGradient;


    [SerializeField] private Texture externalForce;
    [SerializeField] private Texture externalForceColor;
    [SerializeField] private Texture qtyInitialState;
    [SerializeField] private Vector2Int simulationSize = new Vector2Int(1024, 1024);

    [SerializeField] private RawImage qtyDebug, uDebug, pDivergenceDebug ,pDebug;

    [SerializeField] private int diffusionIteration = 20;
    [SerializeField] private int computePressureIteration = 40;
    [SerializeField] private float qtyCarryFactory = 0.5f;
    [SerializeField] private float velocityAdvectionFactor = 0.5f;

    private RenderTexture qty;
    private RenderTexture u;
    private RenderTexture p;

    private RenderTexture temp;
    private RenderTexture viscosityTemp;
    private RenderTexture pressureTemp;
    private RenderTexture pressureDivergenceTemp;

    private Material qtyInputMaterial;
    private Material velocityAdvectionMaterial;
    private Material advectionMaterial;
    private Material diffuseMaterial;
    private Material forceMaterial;
    private Material pressureDivergenceMaterial;
    private Material computePressureMaterial;
    private Material substractPressureGradientMaterial;

    private void Start() {
        qty = new RenderTexture(simulationSize.x, simulationSize.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        u = new RenderTexture(simulationSize.x, simulationSize.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        p = new RenderTexture(simulationSize.x, simulationSize.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        ClearColor(u, new Color(0.5f, 0.5f, 1, 1));
        ClearColor(u, new Color(0.5f, 0.5f, 0.5f, 1));

        temp = new RenderTexture(simulationSize.x, simulationSize.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        viscosityTemp = new RenderTexture(simulationSize.x, simulationSize.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        pressureTemp = new RenderTexture(simulationSize.x, simulationSize.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        pressureDivergenceTemp = new RenderTexture(simulationSize.x, simulationSize.y, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);

        qtyInputMaterial = new Material(qtyInput);
        velocityAdvectionMaterial = new Material(advection);
        advectionMaterial = new Material(advection);
        diffuseMaterial = new Material(diffuse);
        forceMaterial = new Material(force);
        pressureDivergenceMaterial = new Material(pressureDivergence);
        computePressureMaterial = new Material(computePressure);
        substractPressureGradientMaterial = new Material(substractPresureGradient);

        qtyInputMaterial.SetTexture("_Input", externalForceColor);
        velocityAdvectionMaterial.SetTexture("_U", u);
        velocityAdvectionMaterial.SetFloat("_CarryF", velocityAdvectionFactor);
        advectionMaterial.SetTexture("_U", u);
        advectionMaterial.SetFloat("_CarryF", qtyCarryFactory);
        diffuseMaterial.SetTexture("_U", u);
        diffuseMaterial.SetFloat("_InterationCount", diffusionIteration);
        forceMaterial.SetTexture("_F", externalForce);
        computePressureMaterial.SetTexture("_P_Divergence",pressureDivergenceTemp);
        computePressureMaterial.SetFloat("_InterationCount", computePressureIteration);
        substractPressureGradientMaterial.SetTexture("_P", p);

        Graphics.Blit(qtyInitialState, qty);

        CommandBuffer commandBuffer= new CommandBuffer();
        commandBuffer.Blit(qty, temp, qtyInputMaterial);
        commandBuffer.Blit(temp, qty);
        commandBuffer.Blit(u, temp, velocityAdvectionMaterial);
        commandBuffer.Blit(temp, u);
        commandBuffer.Blit(qty, temp, advectionMaterial);
        commandBuffer.Blit(temp, qty);

        //Jacobsky for viscosity
        commandBuffer.Blit(u, viscosityTemp);
        for (int i = 0; i < diffusionIteration; i++)
        {
            commandBuffer.Blit(viscosityTemp, temp, diffuseMaterial);
            commandBuffer.Blit(temp, viscosityTemp);
        }
        commandBuffer.Blit(viscosityTemp, u);

        commandBuffer.Blit(u, temp, forceMaterial);
        commandBuffer.Blit(temp, u);

        //divergence
        commandBuffer.Blit(u, pressureDivergenceTemp, pressureDivergenceMaterial);

        //Jacobsky for pressure
        commandBuffer.Blit(p, pressureTemp);
        for (int i = 0; i < computePressureIteration; i++)
        {
            commandBuffer.Blit(pressureTemp, temp, computePressureMaterial);
            commandBuffer.Blit(temp, pressureTemp);
        }
        commandBuffer.Blit(pressureTemp, p);

        commandBuffer.Blit(u, temp, substractPressureGradientMaterial);
        commandBuffer.Blit(temp, u);

        Camera.main.AddCommandBuffer(CameraEvent.AfterEverything, commandBuffer);

        if(qtyDebug != null)
            qtyDebug.texture = qty;
        if(uDebug != null)
            uDebug.texture = u;
        if(pDivergenceDebug != null)
            pDivergenceDebug.texture = pressureDivergenceTemp;
        if(pDebug != null)
            pDebug.texture = p;
    }

    private void ClearColor(RenderTexture buffer, Color color)
    {
        RenderTexture.active = buffer;
        GL.Clear(true, true, color);
        RenderTexture.active = null;
    }

    private void OnDestroy() {
        Destroy(temp);
        Destroy(viscosityTemp);
        Destroy(pressureTemp);
        Destroy(pressureDivergenceTemp);
        Destroy(qty);
        Destroy(u);
        Destroy(p);

        Destroy(qtyInputMaterial);
        Destroy(velocityAdvectionMaterial);
        Destroy(advectionMaterial);
        Destroy(diffuseMaterial);
        Destroy(forceMaterial);
        Destroy(pressureDivergenceMaterial);
        Destroy(computePressureMaterial);
        Destroy(substractPressureGradientMaterial);
    }
}
