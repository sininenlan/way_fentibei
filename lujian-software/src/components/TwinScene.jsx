import { useEffect, useRef } from "react";
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { formatCoordinate } from "../lib/format";

const colors = {
  high: 0xd44f35,
  medium: 0xd88a2d,
  low: 0x2f7a6c,
};

function addBox(scene, size, position, material) {
  const geometry = new THREE.BoxGeometry(...size);
  const mesh = new THREE.Mesh(geometry, material);
  mesh.position.set(...position);
  scene.add(mesh);
  return mesh;
}

export default function TwinScene({ defects, selectedDefect }) {
  const mountRef = useRef(null);

  useEffect(() => {
    const mount = mountRef.current;
    if (!mount) return undefined;
    const width = mount.clientWidth || 600;
    const height = mount.clientHeight || 320;
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x17201e);
    scene.fog = new THREE.Fog(0x17201e, 23, 42);

    const camera = new THREE.PerspectiveCamera(44, width / height, 0.1, 100);
    camera.position.set(16, 11, 17);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    mount.appendChild(renderer.domElement);

    const controls = new OrbitControls(camera, renderer.domElement);
    controls.target.set(0, 0.2, 0);
    controls.enableDamping = true;
    controls.dampingFactor = 0.06;
    controls.autoRotate = true;
    controls.autoRotateSpeed = 0.32;
    controls.enablePan = false;
    controls.minDistance = 13;
    controls.maxDistance = 29;
    controls.maxPolarAngle = Math.PI * 0.46;

    scene.add(new THREE.HemisphereLight(0xdce9e2, 0x1c2825, 2.2));
    const keyLight = new THREE.DirectionalLight(0xfff3dd, 2.8);
    keyLight.position.set(10, 18, 9);
    scene.add(keyLight);

    const asphalt = new THREE.MeshStandardMaterial({
      color: 0x303936,
      roughness: 0.92,
      metalness: 0.04,
    });
    const shoulderMaterial = new THREE.MeshStandardMaterial({
      color: 0x68736e,
      roughness: 0.95,
    });
    const lineMaterial = new THREE.MeshStandardMaterial({
      color: 0xd9d5c8,
      roughness: 0.75,
    });
    const edgeMaterial = new THREE.MeshStandardMaterial({
      color: 0xf0a25f,
      emissive: 0x6b2e10,
      emissiveIntensity: 0.25,
      roughness: 0.65,
    });

    addBox(scene, [31, 0.22, 2], [0, -0.02, -4.5], shoulderMaterial);
    addBox(scene, [31, 0.22, 2], [0, -0.02, 4.5], shoulderMaterial);
    addBox(scene, [31, 0.32, 7], [0, 0.12, 0], asphalt);
    addBox(scene, [31, 0.034, 0.1], [0, 0.31, -3.44], edgeMaterial);
    addBox(scene, [31, 0.034, 0.1], [0, 0.31, 3.44], edgeMaterial);

    for (let x = -14; x <= 14; x += 2.3) {
      addBox(scene, [1.16, 0.025, 0.1], [x, 0.305, 0], lineMaterial);
    }

    const grid = new THREE.GridHelper(38, 38, 0x33413d, 0x26312e);
    grid.position.y = -0.16;
    scene.add(grid);

    const sorted = [...defects]
      .sort((a, b) => a.lng - b.lng)
      .slice(0, 16);
    const minLng = Math.min(...sorted.map((defect) => defect.lng), 109);
    const maxLng = Math.max(...sorted.map((defect) => defect.lng), 110);
    const span = Math.max(maxLng - minLng, 0.001);
    sorted.forEach((defect, index) => {
      const active = selectedDefect?.id === defect.id;
      const x = ((defect.lng - minLng) / span) * 24 - 12;
      const z = ((index % 3) - 1) * 1.8;
      const color = colors[defect.severity] || colors.low;
      const beaconMaterial = new THREE.MeshStandardMaterial({
        color,
        emissive: color,
        emissiveIntensity: active ? 1.3 : 0.55,
        transparent: true,
        opacity: active ? 0.98 : 0.7,
        roughness: 0.35,
      });
      const ring = new THREE.Mesh(
        new THREE.TorusGeometry(active ? 0.52 : 0.32, active ? 0.08 : 0.045, 12, 36),
        beaconMaterial,
      );
      ring.rotation.x = Math.PI / 2;
      ring.position.set(x, 0.33, z);
      scene.add(ring);

      const beaconHeight = active ? 2.25 : 1.25 + defect.terminalCount * 0.06;
      const beacon = new THREE.Mesh(
        new THREE.CylinderGeometry(0.035, 0.035, beaconHeight, 10),
        beaconMaterial,
      );
      beacon.position.set(x, 0.33 + beaconHeight / 2, z);
      scene.add(beacon);

      const top = new THREE.Mesh(
        new THREE.SphereGeometry(active ? 0.17 : 0.1, 16, 16),
        beaconMaterial,
      );
      top.position.set(x, 0.33 + beaconHeight, z);
      scene.add(top);
    });

    let frameId = 0;
    const animate = () => {
      frameId = requestAnimationFrame(animate);
      controls.update();
      renderer.render(scene, camera);
    };
    animate();

    const onResize = () => {
      const nextWidth = mount.clientWidth || 600;
      const nextHeight = mount.clientHeight || 320;
      camera.aspect = nextWidth / nextHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(nextWidth, nextHeight);
    };
    const observer = new ResizeObserver(onResize);
    observer.observe(mount);

    return () => {
      cancelAnimationFrame(frameId);
      observer.disconnect();
      controls.dispose();
      renderer.dispose();
      scene.traverse((object) => {
        if (object.geometry) object.geometry.dispose();
        if (object.material) {
          if (Array.isArray(object.material)) {
            object.material.forEach((material) => material.dispose());
          } else {
            object.material.dispose();
          }
        }
      });
      if (renderer.domElement.parentNode === mount) {
        mount.removeChild(renderer.domElement);
      }
    };
  }, [defects, selectedDefect]);

  return (
    <div className="twin-scene">
      <div ref={mountRef} className="twin-canvas" />
      <div className="twin-hud-top">
        <span className="hud-kicker">ROAD DIGITAL TWIN</span>
        <strong>{selectedDefect?.roadCode || "G312 · 灞桥示范段"}</strong>
        <span>{selectedDefect?.type || "道路资产与病害实时映射"}</span>
      </div>
      <div className="twin-hud-bottom">
        <span>
          {selectedDefect
            ? `${formatCoordinate(selectedDefect.lat, "lat")} / ${formatCoordinate(selectedDefect.lng, "lng")}`
            : "34.274200° N / 109.067800° E"}
        </span>
        <span className="twin-live"><i /> LIVE MESH</span>
      </div>
    </div>
  );
}
